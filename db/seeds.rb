# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user1 = User.create! name: 'Seth Jeffery', email: 'seth@sethjeffery.com', password: 'password'
user2 = User.create! name: 'Ana Jeffery', email: 'anajeffery@hotmail.co.uk', password: 'password'
user3 = User.create! name: 'Faith Jeffery', email: 'faith@sethjeffery.com', password: 'password'

event1 = Event.create! name: 'Baby shower', starts_at: Date.today, ends_at: Date.today + 1.week, creator: user1
event2 = Event.create! name: 'Church',      starts_at: Date.today + 5.days, ends_at: Date.today + 10.days, creator: user1

event_user1 = event1.event_users.create user: user1
event_user1.times.create time: Time.now
event_user1.times.create time: Time.now + 1.day

event1.event_users.create user: user2
event2.event_users.create user: user3
