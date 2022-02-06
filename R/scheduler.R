library("taskscheduleR")
taskscheduler_create(taskname = "vqgan_run", 
                     rscript = here::here("R/runvqgan.R"), 
                     schedule = "DAILY", starttime = "23:00")
# tsk <- taskscheduler_ls()
# tsk[tsk$Aufgabenname=="vqgan_run",]
# taskscheduler_delete("vqgan_run")
