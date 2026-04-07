env :PATH, ENV["PATH"]

set :output, "/home/theshiftbraker/trabalhos/2026/siteia26/log/cron.log"

every 10.minutes do
  rake "noticias:sincronizar"
end

every 1.day, at: "3:00 am" do
  rake "diarios:sincronizar"
end
