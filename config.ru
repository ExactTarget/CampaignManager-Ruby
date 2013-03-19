require "./init.rb"

Main.set :run, false
env = ((ENV['RACK_ENV'] == 'development' or !ENV['RACK_ENV']) ? (:development) : (:production))

Main.set :environment, env

run Main
