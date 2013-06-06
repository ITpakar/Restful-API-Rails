# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

jed = User.create(full_name: "Jed Seculles", email: "jeds@local.loc", password: "123123123")
nikki = User.create(full_name: "Nikki Fernandez", email: "nikkif@local.loc", password: "123123123")
andy = User.create(full_name: "Jonathan Andy Lim", email: "andyl@local.loc", password: "123123123")
jedford = User.create(full_name: "Jedford Seculles", email: "jedfords@local.loc", password: "123123123")
jedford = User.create(full_name: "Jeff Seculles", email: "jeffs@local.loc", password: "123123123")

jed.followed_by_self << [nikki, andy]

post1 = nikki.posts.create(quote: "Lorem ipsum dolor", caption: "Lorem ipsum dolor #sit #amet", author_name: "Auctor Convallis")
post2 = andy.posts.create(quote: "Lorem ipsum dolor", caption: "Ipsum dolor sit #amet #consectetur #adipiscing", author_name: "Auctor Convallis")

jed.liked_posts << [post1, post2]

comment1 = post1.comments.create(body: "Donec arcu arcu")
comment2 = post2.comments.create(body: "Scelerisque eu commodo euismod")
comment3 = post2.comments.create(body: "Molestie ac ipsum")

jed.comments << [comment1, comment2, comment3]

admin = Admin.create(email: 'quotiful01@gmail.com', password: 'quotiful123', password_confirmation: 'quotiful123')