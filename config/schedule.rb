env :PATH, ENV["PATH"]

set :environment, :production
set :output, Rails.root.join("log", "cron.log")

every 1.day, at: "3:00 am" do
  rake "diarios:sincronizar"
end
