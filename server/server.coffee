Topics = new Meteor.Collection("topics")
Things = new Meteor.Collection("things")
Actions = new Meteor.Collection("actions")
AdminRequests = new Meteor.Collection("admin_requests")


Meteor.publish "topics", ->
  Topics.find {}
Meteor.publish "things", ->
  Things.find {}, {sort: {'name': 1}}
Meteor.publish "actions", ->
  Actions.find {}
Meteor.publish "adminRequests", ->
  AdminRequests.find {}


Meteor.startup ->
  if Meteor.users.find({}).count() == 0
    options =
      email: 'nickwarner@gmail.com'
      password: 'password'
    Accounts.createUser(options)
    user = Meteor.users.findOne({})
    Roles.addUsersToRoles(user._id, ["admin"]);

is_admin = ->
  Roles.userIsInRole(Meteor.user(), "admin")

Topics.allow
  insert: (userId, doc) ->
    is_admin?
  remove: (userId, doc) ->
    is_admin?
  update: (userId, docs, fields, modifier) ->
    is_admin?

Things.allow
  insert: (userId, doc) ->
    is_admin?
  remove: (userId, doc) ->
    is_admin?
  update: (userId, docs, fields, modifier) ->
    is_admin?

Actions.allow
  insert: (userId, doc) ->
    userId && doc.user_id == userId
  remove: (userId, doc) ->
    userId && doc.user_id == userId

AdminRequests.allow
  insert: (userId, doc) ->
    true
  remove: (userId, doc) ->
    is_admin?
  update: (userId, docs, fields, modifier) ->
    is_admin?


approve_admin_request = (admin_request_id) ->
  if is_admin?
    admin_request = AdminRequest.findOne admin_request_id
    Meteor.users.update Meteor.userId, {admin: true}
    AdminRequest.remove admin_request_id

ignore_admin_request = (admin_request_id) ->
  if is_admin?
    AdminRequest.remove admin_request_id

