# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ProductType.create [{:name => 'Whiskey'},
                    {:name => 'Clothing'},
                    {:name => 'Glassware'},
                    {:name => 'Giftcard'}]
OrderStatus.create [{:name => 'New'},
                    {:name => 'Filled'},
                    {:name => 'Picked-up'},
                    {:name => 'Canceled'}]
CancelReason.create [{:name => 'Customer'},
                     {:name => 'Product Not Available'},
                     {:name => 'Miscellaneous'}]
MessageType.create [{name: 'Customer Inquiry', description: 'Customer initiated message sent to site administrators.', active: true}]
State.create [{name: 'Illinois', abbr: 'IL', active: true},
              {name: 'Indiana', abbr: 'IN', active: true},
              {name: 'Iowa', abbr: 'IA', active: false},
              {name: 'Michigan', abbr: 'MI', active: true},
              {name: 'Minnesota', abbr: 'MN', active: true},
              {name: 'Wisconsin', abbr: 'WI', active: true}]