Topics = new Meteor.Collection("topics")
Things = new Meteor.Collection("things")
Actions = new Meteor.Collection("actions")
AdminRequests = new Meteor.Collection("admin_requests")


Meteor.publish "topics", ->
  Topics.find {}
Meteor.publish "things", ->
  Things.find {}
Meteor.publish "actions", ->
  Actions.find {}
Meteor.publish "adminRequests", ->
  AdminRequests.find {}

Meteor.publish "userData", ->
  Meteor.users.find({_id: this.userId}, {fields: {'admin': false}})


Topics.allow 
  insert: (userId, doc) ->
    Meteor.user().admin
  remove: (userId, doc) ->
    Meteor.user().admin
  update: (userId, docs, fields, modifier) ->
    Meteor.user().admin

Things.allow
  insert: (userId, doc) ->
    Meteor.user().admin
  remove: (userId, doc) ->
    Meteor.user().admin
  update: (userId, docs, fields, modifier) ->
    Meteor.user().admin

Actions.allow
  insert: (userId, doc) ->
    userId && doc.user_id == userId
  remove: (userId, doc) ->
    userId && doc.user_id == userId

AdminRequests.allow
  insert: (userId, doc) ->
    true
  remove: (userId, doc) ->
    Meteor.user().admin
  update: (userId, docs, fields, modifier) ->
    Meteor.user().admin

# If no user is admin, set the next user to login as admin
#Deps.autorun ->
#  if Meteor.user() && !Meteor.users.findOne({admin:true})
#    console.log 'Granting admin to ' + Meteor.user().profile.name
#    #Meteor.users.update Meteor.user()._id, {admin: true}


approve_admin_request = (admin_request_id) ->
  if Meteor.user().admin
    admin_request = AdminRequest.findOne admin_request_id
    Meteor.users.update Meteor.userId, {admin: true}
    AdminRequest.remove admin_request_id

ignore_admin_request = (admin_request_id) ->
  if Meteor.user().admin
    AdminRequest.remove admin_request_id

