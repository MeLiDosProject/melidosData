options(stringsAsFactors = FALSE, scipen = 999)

pkgs <- c("dplyr","tidyr","purrr","stringr","lubridate","readr","ggplot2","tibble","scales","melidosData")
invisible(lapply(pkgs, require, character.only = TRUE))
options(dplyr.summarise.inform = FALSE)

out <- "darkness_full_cohort"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(out,"figures"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(out,"tables"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(out,"data"), showWarnings = FALSE, recursive = TRUE)

sites <- c("BAUA","FUSPCEU","IZTECH","KNUST","MPI","RISE","THUAS","TUM","UCR")
tzs <- melidosData::melidos_tzs[sites]
thresholds <- c(0.1,0.3,1,3,10)
transition_targets <- c(10,50,100,250)

norm_name <- function(x) stringr::str_to_lower(stringr::str_replace_all(x,"[^a-z0-9]",""))

pick_col <- function(df, candidates, required=TRUE) {
  nms <- names(df); nn <- norm_name(nms)
  cc <- norm_name(candidates)
  for (cand in cc) {
    hit <- which(nn == cand)
    if (length(hit) == 1L) return(nms[hit])
  }
  if (required) stop("Could not resolve one of: ", paste(candidates, collapse=", "),
                     ". Available: ", paste(nms, collapse=", "))
  NA_character_
}

to_local <- function(x, tz) {
  if (inherits(x,"POSIXt")) {
    z <- attr(x,"tzone", exact=TRUE)
    z <- if (is.null(z) || !length(z)) "" else as.character(z)[1]
    if (nzchar(z)) lubridate::with_tz(x, tz) else lubridate::force_tz(x, tz)
  } else {
    suppressWarnings(lubridate::parse_date_time(
      as.character(x),
      orders=c("Ymd HMS","Ymd HM","Y-m-d H:M:S","Y-m-d H:M",
               "dmy HMS","dmy HM","dmY HMS","dmY HM","mdy HMS","mdy HM"),
      tz=tz, exact=FALSE
    ))
  }
}

message("Loading all nine sites...")
head_list <- melidosData::load_data("light_glasses_1minute", site="all")
sleep_list <- melidosData::load_data("sleepdiaries", site="all")
wear_list <- melidosData::load_data("wearlog", site="all")

# ---------- Light ----------
standardize_light <- function(site, df) {
  if (is.null(df) || !is.data.frame(df)) return(tibble())
  idc <- pick_col(df,c("Id","record_id","participant","participant_id"))
  tc <- pick_col(df,c("Datetime","datetime","timestamp","date_time"))
  lc <- pick_col(df,c("MEDI","melEDI","melanopic_edi","melanopic EDI"))
  tz <- unname(tzs[[site]])
  tibble(
    site=site,
    participant=as.character(df[[idc]]),
    datetime=to_local(df[[tc]],tz),
    light=as.numeric(df[[lc]])
  ) |>
    filter(!is.na(participant), !is.na(datetime), is.finite(light), light >= 0) |>
    arrange(participant,datetime) |>
    distinct(participant,datetime,.keep_all=TRUE)
}
light <- purrr::imap_dfr(head_list, ~standardize_light(.y,.x))
stopifnot(nrow(light)>0)

# ---------- Sleep diaries -> explicit waking intervals ----------
standardize_sleep <- function(site, df) {
  if (is.null(df) || !is.data.frame(df)) return(tibble())
  idc <- pick_col(df,c("Id","record_id"))
  bc <- pick_col(df,c("bedtime","bed_time"))
  oc <- pick_col(df,c("out_ofbed","outofbed","out_of_bed"))
  tz <- unname(tzs[[site]])
  tibble(
    site=site,
    participant=as.character(df[[idc]]),
    bedtime=to_local(df[[bc]],tz),
    out_ofbed=to_local(df[[oc]],tz)
  ) |>
    filter(!is.na(participant))
}
sleep <- purrr::imap_dfr(sleep_list, ~standardize_sleep(.y,.x))

build_wake_intervals <- function(dat) {
  dat <- arrange(dat, participant, out_ofbed, bedtime)
  res <- list(); k <- 1L
  for (pid in unique(dat$participant)) {
    d <- dat[dat$participant==pid,,drop=FALSE]
    wakes <- sort(unique(d$out_ofbed[!is.na(d$out_ofbed)]))
    beds <- sort(unique(d$bedtime[!is.na(d$bedtime)]))
    if (!length(wakes) || !length(beds)) next
    for (w in wakes) {
      b <- beds[beds > w]
      if (!length(b)) next
      b <- b[1]
      hrs <- as.numeric(difftime(b,w,units="hours"))
      if (is.finite(hrs) && hrs >= 2 && hrs <= 30) {
        res[[k]] <- tibble(site=d$site[1], participant=pid,
                           wake_start=w, wake_end=b,
                           wake_day=as.Date(w, tz=unname(tzs[[d$site[1]]])))
        k <- k+1L
      }
    }
  }
  bind_rows(res) |> distinct(site,participant,wake_start,wake_end,.keep_all=TRUE)
}
wake_intervals <- sleep |> group_split(site) |> map_dfr(build_wake_intervals)
readr::write_csv(wake_intervals,file.path(out,"data","wake_intervals.csv"))

# ---------- Wear log off/sleep intervals ----------
standardize_wear <- function(site, df) {
  if (is.null(df) || !is.data.frame(df)) return(tibble())
  idc <- pick_col(df,c("Id","record_id"))
  sc <- pick_col(df,c("start","wear_start"),required=FALSE)
  ec <- pick_col(df,c("end","wear_end"),required=FALSE)
  stc <- pick_col(df,c("state","event"),required=FALSE)
  if (is.na(sc) || is.na(ec) || is.na(stc)) return(tibble())
  tz <- unname(tzs[[site]])
  tibble(
    site=site,
    participant=as.character(df[[idc]]),
    start=to_local(df[[sc]],tz),
    end=to_local(df[[ec]],tz),
    state=tolower(as.character(df[[stc]]))
  ) |>
    filter(state %in% c("off","sleep"), !is.na(start), !is.na(end), end>start)
}
wear_intervals <- purrr::imap_dfr(wear_list, ~standardize_wear(.y,.x))
readr::write_csv(wear_intervals,file.path(out,"data","wear_off_sleep_intervals.csv"))

# ---------- Assign every light sample to a diary-bounded waking interval ----------
light$wake_day <- as.Date(NA)
light$wake_start <- as.POSIXct(NA)
light$wake_end <- as.POSIXct(NA)
light$off_logged <- FALSE

idx_by_site_pid <- split(seq_len(nrow(light)), paste(light$site,light$participant,sep="||"))
wi_split <- split(wake_intervals, paste(wake_intervals$site,wake_intervals$participant,sep="||"))
wear_split <- split(wear_intervals, paste(wear_intervals$site,wear_intervals$participant,sep="||"))

for (key in names(idx_by_site_pid)) {
  ix <- idx_by_site_pid[[key]]
  tt <- light$datetime[ix]
  if (key %in% names(wi_split)) {
    w <- wi_split[[key]]
    # intervals should not overlap; assign the first matching interval
    for (j in seq_len(nrow(w))) {
      hit <- which(is.na(light$wake_day[ix]) & tt >= w$wake_start[j] & tt < w$wake_end[j])
      if (length(hit)) {
        ii <- ix[hit]
        light$wake_day[ii] <- w$wake_day[j]
        light$wake_start[ii] <- w$wake_start[j]
        light$wake_end[ii] <- w$wake_end[j]
      }
    }
  }
  if (key %in% names(wear_split)) {
    w <- wear_split[[key]]
    for (j in seq_len(nrow(w))) {
      hit <- tt >= w$start[j] & tt <= w$end[j]
      if (any(hit,na.rm=TRUE)) light$off_logged[ix[which(hit)]] <- TRUE
    }
  }
}

wake_light <- light |> filter(!is.na(wake_day), !off_logged) |>
  mutate(pid_day=paste(site,participant,wake_day,sep="__"))

coverage <- wake_light |>
  group_by(site,participant,wake_day,pid_day) |>
  summarise(valid_minutes=n(), valid_hours=n()/60, .groups="drop")

valid_days <- coverage |> filter(valid_hours >= 8)
valid_participants <- valid_days |> count(site,participant,name="valid_days") |> filter(valid_days >= 2)

analysis <- wake_light |>
  semi_join(valid_days,by=c("site","participant","wake_day","pid_day")) |>
  semi_join(valid_participants,by=c("site","participant")) |>
  arrange(site,participant,datetime)

sample_by_site <- analysis |>
  distinct(site,participant,pid_day) |>
  count(site,participant,name="days") |>
  group_by(site) |>
  summarise(participants=n(),participant_days=sum(days),median_days=median(days),.groups="drop") |>
  left_join(analysis |> count(site,name="waking_minutes"),by="site") |>
  mutate(waking_hours=waking_minutes/60)
readr::write_csv(sample_by_site,file.path(out,"tables","sample_by_site.csv"))

audit <- tibble(
  metric=c("raw_valid_light_minutes","diary_bounded_minutes_after_wearlog","analytic_minutes",
           "analytic_participants","analytic_participant_days"),
  value=c(nrow(light),nrow(wake_light),nrow(analysis),
          n_distinct(analysis$participant),
          n_distinct(analysis$pid_day))
)
readr::write_csv(audit,file.path(out,"tables","analysis_audit.csv"))

# ---------- Threshold prevalence ----------
thr_rows <- map_dfr(thresholds,function(th){
  analysis |>
    group_by(site,participant) |>
    summarise(minutes=n(), dark_minutes=sum(light < th), proportion=dark_minutes/minutes,.groups="drop") |>
    mutate(threshold=th)
})
readr::write_csv(thr_rows,file.path(out,"data","participant_threshold_prevalence.csv"))

thr_summary <- thr_rows |>
  group_by(threshold) |>
  summarise(participants=n(),median_pct=100*median(proportion),
            q25_pct=100*quantile(proportion,.25),q75_pct=100*quantile(proportion,.75),
            .groups="drop")
readr::write_csv(thr_summary,file.path(out,"tables","threshold_prevalence_pooled.csv"))

thr_site <- thr_rows |>
  group_by(site,threshold) |>
  summarise(participants=n(),median_pct=100*median(proportion),
            q25_pct=100*quantile(proportion,.25),q75_pct=100*quantile(proportion,.75),
            .groups="drop")
readr::write_csv(thr_site,file.path(out,"tables","threshold_prevalence_by_site.csv"))

daily_thr <- map_dfr(thresholds,function(th){
  analysis |>
    group_by(site,participant,pid_day,wake_day) |>
    summarise(dark_minutes=sum(light<th),.groups="drop") |>
    group_by(site,participant) |>
    summarise(participant_median_daily_minutes=median(dark_minutes),.groups="drop") |>
    mutate(threshold=th)
})
daily_summary <- daily_thr |>
  group_by(threshold) |>
  summarise(participants=n(),median_minutes=median(participant_median_daily_minutes),
            q25_minutes=quantile(participant_median_daily_minutes,.25),
            q75_minutes=quantile(participant_median_daily_minutes,.75),.groups="drop")
readr::write_csv(daily_summary,file.path(out,"tables","daily_dark_minutes_pooled.csv"))

p1 <- ggplot(thr_summary,aes(x=factor(threshold,levels=thresholds),y=median_pct))+
  geom_point(size=3)+
  geom_errorbar(aes(ymin=q25_pct,ymax=q75_pct),width=.15)+
  labs(x="Operational darkness threshold (melanopic EDI lx)",
       y="Participant-level waking time below threshold (%)",
       title="Very-low-light exposure during confirmed waking wear",
       subtitle="Median and interquartile range across participants")+
  theme_minimal(base_size=12)
ggsave(file.path(out,"figures","threshold_prevalence.png"),p1,width=8,height=5,dpi=180)

# ---------- Bout extraction ----------
extract_bouts <- function(df, th) {
  df |>
    arrange(site,participant,pid_day,datetime) |>
    group_by(site,participant,pid_day,wake_day) |>
    mutate(
      dark=light < th,
      gap_sec=as.numeric(difftime(datetime,lag(datetime),units="secs")),
      newrun=row_number()==1L | dark != lag(dark,default=first(dark)) |
        (!is.na(gap_sec) & gap_sec > 90),
      run=cumsum(newrun)
    ) |>
    ungroup() |>
    filter(dark) |>
    group_by(site,participant,pid_day,wake_day,run) |>
    summarise(
      start=min(datetime),end=max(datetime),
      duration_min=as.numeric(difftime(max(datetime),min(datetime),units="mins"))+1,
      samples=n(),median_light=median(light),min_light=min(light),max_light=max(light),
      .groups="drop"
    ) |>
    mutate(threshold=th,bout_id=paste(site,participant,pid_day,th,run,sep="||"))
}
bouts1 <- extract_bouts(analysis,1)
bouts3 <- extract_bouts(analysis,3)
bouts <- bind_rows(bouts1,bouts3)
readr::write_csv(bouts,file.path(out,"data","darkness_bouts_1_and_3_lux.csv"))

bout_summary <- bouts |>
  group_by(threshold) |>
  summarise(
    bouts=n(),participants=n_distinct(participant),
    event_median_min=median(duration_min),event_q25_min=quantile(duration_min,.25),
    event_q75_min=quantile(duration_min,.75),event_p95_min=quantile(duration_min,.95),
    .groups="drop"
  )
longest <- bouts |>
  group_by(site,participant,threshold) |>
  summarise(longest_bout_min=max(duration_min),.groups="drop")
longest_summary <- longest |>
  group_by(threshold) |>
  summarise(participants=n(),median_longest_min=median(longest_bout_min),
            q25_longest_min=quantile(longest_bout_min,.25),
            q75_longest_min=quantile(longest_bout_min,.75),
            .groups="drop")
readr::write_csv(bout_summary,file.path(out,"tables","bout_summary.csv"))
readr::write_csv(longest_summary,file.path(out,"tables","longest_bout_summary.csv"))

bout_site <- bouts |>
  group_by(site,threshold) |>
  summarise(bouts=n(),participants=n_distinct(participant),
            median_duration=median(duration_min),p95_duration=quantile(duration_min,.95),.groups="drop")
readr::write_csv(bout_site,file.path(out,"tables","bout_summary_by_site.csv"))

# start-time distribution for bouts >=5 min
bout_timing <- bouts |>
  filter(duration_min>=5) |>
  mutate(hour=lubridate::hour(start)+lubridate::minute(start)/60,
         time_band=cut(hour,breaks=c(-Inf,6,12,18,24,Inf),
                       labels=c("00:00–05:59","06:00–11:59","12:00–17:59","18:00–23:59","other"),
                       right=FALSE)) |>
  count(threshold,time_band,name="bouts") |>
  group_by(threshold) |>
  mutate(percent=100*bouts/sum(bouts)) |>
  ungroup()
readr::write_csv(bout_timing,file.path(out,"tables","bout_start_time_distribution.csv"))

# ---------- Transitions after darkness ----------
split_day <- split(analysis,paste(analysis$site,analysis$participant,analysis$pid_day,sep="||"))

find_transitions <- function(bout_df, th) {
  bb <- bout_df |> filter(duration_min>=5)
  ans <- vector("list",nrow(bb)*length(transition_targets)); k <- 1L
  for (i in seq_len(nrow(bb))) {
    b <- bb[i,]
    key <- paste(b$site,b$participant,b$pid_day,sep="||")
    d <- split_day[[key]]
    if (is.null(d) || !nrow(d)) next
    num <- as.numeric(d$datetime)
    en <- as.numeric(b$end)
    ix <- which(num > en & num <= en+30*60)
    if (!length(ix)) next
    for (target in transition_targets) {
      hit <- ix[d$light[ix] >= target]
      if (!length(hit)) next
      h <- hit[1]
      ans[[k]] <- tibble(
        site=b$site,participant=b$participant,pid_day=b$pid_day,
        threshold=th,target=target,bout_id=b$bout_id,
        dark_start=b$start,dark_end=b$end,dark_duration_min=b$duration_min,
        transition_time=d$datetime[h],
        minutes_to_target=as.numeric(difftime(d$datetime[h],b$end,units="mins")),
        target_light=d$light[h]
      )
      k <- k+1L
    }
  }
  bind_rows(ans)
}
transitions <- bind_rows(find_transitions(bouts1,1),find_transitions(bouts3,3))
readr::write_csv(transitions,file.path(out,"data","darkness_to_light_transitions.csv"))

transition_summary <- transitions |>
  group_by(threshold,target) |>
  summarise(
    events=n(),participants=n_distinct(participant),sites=n_distinct(site),
    median_prior_dark_min=median(dark_duration_min),
    q25_prior_dark_min=quantile(dark_duration_min,.25),
    q75_prior_dark_min=quantile(dark_duration_min,.75),
    pct_ge30=100*mean(dark_duration_min>=30),
    pct_ge60=100*mean(dark_duration_min>=60),
    pct_ge120=100*mean(dark_duration_min>=120),
    median_minutes_to_target=median(minutes_to_target),
    .groups="drop"
  )
readr::write_csv(transition_summary,file.path(out,"tables","transition_summary.csv"))

transition_site <- transitions |>
  group_by(site,threshold,target) |>
  summarise(events=n(),participants=n_distinct(participant),
            median_prior_dark_min=median(dark_duration_min),.groups="drop")
readr::write_csv(transition_site,file.path(out,"tables","transition_summary_by_site.csv"))

p2dat <- transition_summary |> filter(threshold==1)
p2 <- ggplot(p2dat,aes(x=factor(target,levels=transition_targets),y=median_prior_dark_min))+
  geom_point(size=3)+
  geom_errorbar(aes(ymin=q25_prior_dark_min,ymax=q75_prior_dark_min),width=.15)+
  labs(x="Subsequent light threshold (melanopic EDI lx)",
       y="Duration of preceding <1-lx bout (min)",
       title="Darkness immediately preceding brighter-light transitions",
       subtitle="Events reaching the target within 30 minutes; median and IQR")+
  theme_minimal(base_size=12)
ggsave(file.path(out,"figures","prior_darkness_transitions.png"),p2,width=8,height=5,dpi=180)

# ---------- Algorithmically selected example episodes ----------
eligible <- bouts1 |>
  filter(duration_min>=5) |>
  semi_join(transitions |> filter(threshold==1,target==10) |> distinct(bout_id),by="bout_id")

# Require context on both sides
has_context <- function(b) {
  key <- paste(b$site,b$participant,b$pid_day,sep="||")
  d <- split_day[[key]]
  if (is.null(d) || !nrow(d)) return(FALSE)
  min(d$datetime) <= b$start-lubridate::minutes(20) &&
    max(d$datetime) >= b$end+lubridate::minutes(30)
}
if (nrow(eligible)) {
  keep <- vapply(seq_len(nrow(eligible)),function(i) has_context(eligible[i,]),logical(1))
  eligible <- eligible[keep,,drop=FALSE]
}

targets <- c(10,20,45,90,150)
chosen <- list(); used_sites <- character(); used_participants <- character()
avail <- eligible
for (tg in targets) {
  if (!nrow(avail)) break
  cand <- avail |>
    mutate(site_penalty=site %in% used_sites,
           participant_penalty=participant %in% used_participants,
           distance=abs(duration_min-tg)) |>
    arrange(site_penalty,participant_penalty,distance,desc(duration_min)) |>
    slice(1)
  chosen[[length(chosen)+1L]] <- cand
  used_sites <- c(used_sites,cand$site)
  used_participants <- c(used_participants,cand$participant)
  avail <- avail |> filter(bout_id != cand$bout_id)
}
examples <- bind_rows(chosen)

example_context <- list()
if (nrow(examples)) {
  for (i in seq_len(nrow(examples))) {
    b <- examples[i,]
    key <- paste(b$site,b$participant,b$pid_day,sep="||")
    d <- split_day[[key]] |>
      filter(datetime >= b$start-lubridate::minutes(20),
             datetime <= b$end+lubridate::minutes(30)) |>
      mutate(relative_min=as.numeric(difftime(datetime,b$start,units="mins")),
             example=i,
             facet=paste0(site," | ",participant," | ",format(b$start,"%Y-%m-%d %H:%M"),
                          " | ",round(b$duration_min,1)," min <1 lx"))
    example_context[[i]] <- d
  }
}
ctx <- bind_rows(example_context)
readr::write_csv(ctx,file.path(out,"data","example_episode_traces.csv"))

if (nrow(examples)) {
  ex_table <- examples |>
    transmute(example=row_number(),site,participant,start,end,duration_min,
              median_light,min_light,max_light,bout_id)
  # add context summaries
  extras <- map_dfr(seq_len(nrow(examples)),function(i){
    b <- examples[i,]
    key <- paste(b$site,b$participant,b$pid_day,sep="||")
    d <- split_day[[key]]
    pre <- d |> filter(datetime>=b$start-minutes(20),datetime<b$start)
    post <- d |> filter(datetime>b$end,datetime<=b$end+minutes(30))
    tibble(example=i,
           pre20_median=if(nrow(pre)) median(pre$light) else NA_real_,
           post30_max=if(nrow(post)) max(post$light) else NA_real_,
           post30_median=if(nrow(post)) median(post$light) else NA_real_)
  })
  ex_table <- left_join(ex_table,extras,by="example")
  readr::write_csv(ex_table,file.path(out,"tables","example_darkness_episodes.csv"))

  rect <- examples |>
    mutate(example=row_number(),
           facet=paste0(site," | ",participant," | ",format(start,"%Y-%m-%d %H:%M"),
                        " | ",round(duration_min,1)," min <1 lx"),
           xmin=0,xmax=duration_min,ymin=-Inf,ymax=Inf)
  p3 <- ggplot(ctx,aes(relative_min,pmax(light,0.01)))+
    geom_rect(data=rect,aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax),
              inherit.aes=FALSE,alpha=.12)+
    geom_line(linewidth=.45)+
    geom_hline(yintercept=1,linetype=2)+
    scale_y_log10(labels=scales::label_number())+
    facet_wrap(~facet,ncol=1,scales="free_x")+
    labs(x="Minutes relative to start of <1-lx episode",
         y="Melanopic EDI (lx; log scale)",
         title="Examples of real-world waking darkness episodes",
         subtitle="Shaded interval is the algorithmically selected <1 melanopic EDI lx bout")+
    theme_minimal(base_size=10)
  ggsave(file.path(out,"figures","example_darkness_episodes.png"),p3,width=10,height=11,dpi=180)
}

# ---------- Longest bouts plot ----------
p4 <- ggplot(longest |> filter(threshold==1),aes(x=reorder(site,longest_bout_min,median),y=longest_bout_min))+
  geom_boxplot(outlier.alpha=.3)+
  coord_flip()+
  labs(x="Site",y="Longest waking <1-lx bout per participant (min)",
       title="Longest observed waking darkness bout by site")+
  theme_minimal(base_size=12)
ggsave(file.path(out,"figures","longest_bouts_by_site.png"),p4,width=8,height=6,dpi=180)

# ---------- Human-readable summary ----------
fmt <- function(x,d=1) format(round(x,d),trim=TRUE,nsmall=d)
s1 <- thr_summary |> filter(threshold==1)
s3 <- thr_summary |> filter(threshold==3)
d1 <- daily_summary |> filter(threshold==1)
l1 <- longest_summary |> filter(threshold==1)
tr250 <- transition_summary |> filter(threshold==1,target==250)

lines <- c(
  "# Full-cohort MeLiDos darkness analysis",
  "",
  paste0("Analytic sample: ",n_distinct(analysis$participant)," participants across ",
         n_distinct(analysis$site)," sites, ",n_distinct(analysis$pid_day),
         " participant-days and ",fmt(nrow(analysis)/60,1)," hours of diary-bounded waking wear."),
  "",
  paste0("Median participant-level waking time <1 melanopic EDI lx: ",fmt(s1$median_pct),
         "% (IQR ",fmt(s1$q25_pct),"–",fmt(s1$q75_pct),"%)."),
  paste0("Median participant-level waking time <3 melanopic EDI lx: ",fmt(s3$median_pct),
         "% (IQR ",fmt(s3$q25_pct),"–",fmt(s3$q75_pct),"%)."),
  paste0("Median participant-specific daily time <1 lx: ",fmt(d1$median_minutes),
         " min (IQR ",fmt(d1$q25_minutes),"–",fmt(d1$q75_minutes),")."),
  paste0("Median longest waking <1-lx bout per participant: ",fmt(l1$median_longest_min),
         " min (IQR ",fmt(l1$q25_longest_min),"–",fmt(l1$q75_longest_min),")."),
  "",
  if(nrow(tr250)) paste0("Transitions to >=250 lx within 30 min after >=5 min <1 lx: ",
                         tr250$events," events in ",tr250$participants," participants across ",
                         tr250$sites," sites; median prior darkness ",fmt(tr250$median_prior_dark_min),
                         " min (IQR ",fmt(tr250$q25_prior_dark_min),"–",fmt(tr250$q75_prior_dark_min),
                         "); ",fmt(tr250$pct_ge30),"% >=30 min, ",fmt(tr250$pct_ge60),
                         "% >=60 min, ",fmt(tr250$pct_ge120),"% >=120 min.") else
    "No qualifying transitions to >=250 lx were observed.",
  "",
  "Operational note: darkness is defined from eye-level melanopic EDI measured by ActLumus. It should be described as very-low-light exposure or operational darkness, not physical zero radiance. Logged off/sleep intervals were excluded, and only diary-bounded waking intervals were retained."
)
writeLines(lines,file.path(out,"summary.md"))

# Save session and compact data for independent checking
writeLines(capture.output(sessionInfo()),file.path(out,"sessionInfo.txt"))
saveRDS(list(sample_by_site=sample_by_site,threshold_summary=thr_summary,
             daily_summary=daily_summary,bout_summary=bout_summary,
             longest_summary=longest_summary,transition_summary=transition_summary,
             examples=examples),
        file.path(out,"summary_objects.rds"))

message("DONE")
