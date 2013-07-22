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
    if is_admin()
      'admin'
    else
      'permission_denied'
  '/topic/:topic':
    as: 'topic'
    to: (topic) ->
      Session.set 'topic', topic
      if !Topics.findOne({slug:topic})
        'topic_not_found'
      else
        'topic'
  '/topic/:topic/edit': (topic) ->
    if is_admin()
      Session.set 'topic', topic
      'topic_edit'
    else
      'permission_denied'


current_topic = ->
  Topics.findOne {slug: Session.get('topic')}

user_has_completed_thing = (thing) ->
  Actions.findOne {thing_id: thing._id, user_id: Meteor.userId()}

is_admin = ->
  Roles.userIsInRole(Meteor.user(), "admin")


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

Template.topic_edit_things_item.events
  "click .topic_edit_things_item .delete": ->
    console.log 'topic_edit_things_item', @
    Things.remove @_id

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
  completed_date: ->
    if action = user_has_completed_thing(@)
      moment(action.created_at).fromNow()


Template.topic.rendered = ->
  things_count = $('.thing').length
  $('.things').width((($('.thing').width() * things_count) / 2))

  # Fill out extra squares so it looks more like a cube
  #side = Math.ceil(Math.sqrt(things_count))
  #side_squared = side * side
  #extra_squares = side_squared - things_count
  #console.log things_count, Math.sqrt(things_count)
  #console.log side, side_squared, extra_squares
  #$('.empty_square').remove()
  #_(extra_squares).times ->
  #  $('.things').append('<div class="empty_square"></div>')


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
      Things.find {topic_id: topic._id}, {sort: {'name': 1}}


Template.topic_edit.events
  "click .new_thing .save": ->
    data =
      topic_id: current_topic()._id
      name: $('.new_thing .name').val()
      created_at: Date.now()
    Things.insert data, ->
      $('.new_thing .name').val("")
