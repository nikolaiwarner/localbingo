Topics = new Meteor.Collection("topics")
Things = new Meteor.Collection("things")
Actions = new Meteor.Collection("actions")
AdminRequests = new Meteor.Collection("admin_requests")

Meteor.autosubscribe ->
  Meteor.subscribe("topics")
  Meteor.subscribe("things")
  Meteor.subscribe("actions")
  Meteor.subscribe("admin_requests")

Meteor.Router.add
  '/': 'home'
  '/admin': ->
    if Meteor.user().admin
      'admin'
    else
      'permission_denied'
  '/topic/:topic':
    as: 'topic'
    to: (topic) ->
      if !Topics.findOne({slug:topic})
        console.log 'topic_not_found'
        return 'topic_not_found'
      'topic'
    and: (topic) ->
      Session.set 'topic', topic
  '/topic/:topic/edit': (topic) ->
    if Meteor.user().admin
      Session.set 'topic', topic
      'topic_edit'
    else
      'permission_denied'

###
Meteor.Router.filters
  'checkTopicExists': (topic) ->
    console.log(topic)
    if !Topics.findOne({slug:topic})
      return '/topic/'+topic+'/edit'
    '/topic/'+topic

Meteor.Router.filter('checkTopicExists', {only: '/:topic'})
###


current_topic = ->
  Topics.findOne {slug:Session.get('topic')}

user_has_completed_thing = (thing) ->
  Actions.findOne {thing_id: thing._id, user_id: Meteor.userId()}
  

Template.home.helpers
  topics: ->
    Topics.find {}

Template.admin.helpers
  admin_requests: ->
    AdminRequests.find {}
Template.admin.events
  "click .new_topic .save": ->
    data =
      user_id: Meteor.userId()
      name: $('.new_topic .name').val()
      description: $('.new_topic .description').val()
      slug: $('.new_topic .slug').val()
    Topics.insert data
    $('#new_topic_modal').modal('hide')

Template.admin_request.events
  "click .approve": ->
    Meteor.apply 'approve_admin_request', @_id , ->
      console.log 'Approved!'
  "click .ignore": ->
    Meteor.apply 'ignore_admin_request', @_id , ->
      console.log 'Ignored!'

Template.topic.helpers
  topic: ->
    current_topic()
  things: ->
    Things.find {topic_id: current_topic()._id}


Template.thing.helpers
  completed_class: ->
    if user_has_completed_thing(@)
      'completed'

  
Template.topic.events
  "click .thing": ->
    if user_has_completed_thing(@)
      action_id = Actions.findOne({thing_id: @_id, user_id: Meteor.userId()})._id
      Actions.remove action_id
    else
      data =
        thing_id: @_id
        user_id: Meteor.userId()
        created_at: Date.now()
      Actions.insert data


Template.topic_edit.helpers
  topic: ->
    current_topic()
  things: ->
    if topic = current_topic()
      Things.find {topic_id: topic._id}


Template.topic_edit.events
  "click .new_thing .save": ->
    console.log current_topic()
    data =
      topic_id: current_topic()._id
      name: $('.new_thing .name').val()
      created_at: Date.now()
    Things.insert data
    console.log data
    $('#new_thing_modal').modal('hide')
