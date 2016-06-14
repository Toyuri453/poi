{ROOT, layout, _, $, $$, React, ReactBootstrap, success, warn} = window
{OverlayTrigger, Tooltip, Label} = ReactBootstrap
{join} = require 'path-extra'
{pluck} = require 'underscore'
{connect} = require 'react-redux'
__ = i18n.main.__.bind(i18n.main)
__n = i18n.main.__n.bind(i18n.main)
{MaterialIcon} = require '../../etc/icon'

CountdownLabel = connect(
  (state) ->
    tick: state.tick
) React.createClass
  getTimeRemaining: (completeTime, currentTime) ->
    if completeTime < 0
      -1
    else if completeTime <= currentTime
      0
    else
      Math.round((completeTime - currentTime) / 1000)

  getLabelStyle: (timeRemaining, isLSC) ->
    switch
      when timeRemaining > 600 and isLSC then 'danger'
      when timeRemaining > 600 then 'primary'
      when timeRemaining >  0  then 'warning'
      when timeRemaining is 0  then 'success'
      else 'default'

  render: ->
    timeRemaining = @getTimeRemaining @props.completeTime, @props.tick
    bsStyle = @getLabelStyle timeRemaining, @props.isLSC
    <Label className="kdock-timer" bsStyle={bsStyle}>
    {
      if @props.isInUse && @props.completeTime >= 0
        <span>{resolveTime timeRemaining}</span>
    }
    </Label>


KdockPanel = connect(
  (state) ->
    constructions = state.info.constructions
    $ships = pickId state.const.$ships, pluck(state.info.constructions, 'api_created_ship_id')
    {constructions, $ships}
) React.createClass
  canNotify: false
  handleResponse: (e) ->
    {path, body, postBody} = e.detail
    switch path
      when '/kcsapi/api_start2'
        # Do not notify before entering the game
        @canNotify = false
      when '/kcsapi/api_port/port'
        @canNotify = true
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
  getMaterialImage: (idx) ->
    <MaterialIcon materialId={idx} className="material-icon" />
  constructionIcon: join(ROOT, 'assets', 'img', 'operation', 'build.png')
  notify: ->
    return if not @canNotify
    # Notify all completed ships
    completedShips = @state.docks.filter(
      (dock) -> 0 <= dock.completeTime < Date.now() + 1000).map(
      (dock) -> i18n.resources.__ dock.name).join(', ')
    notify "#{completedShips} #{__ 'built'}",
      type: 'construction'
      title: __ "Construction"
      icon: @constructionIcon
  render: ->
    <div>
    {
      for dock, i in @props.constructions
        dock = dock || {api_state: -1, api_complete_time: 0}
        isLocked = dock.api_state == -1
        isInUse = dock.api_state > 0
        isLSC = isInUse and dock.api_item1 >= 1000
        dockName = switch dock.api_state
          when -1 then __ 'Locked'
          when 0 then __ 'Empty'
          else __ i18n.resources.__ @props.$ships[dock.api_created_ship_id].api_name
        <OverlayTrigger key={i} placement='top' overlay={
          if isInUse
            <Tooltip id="kdock-material-#{i}">
              {
                style = if isLSC then {color: '#D9534F', fontWeight: 'bold'} else null
                <span style={style}>{dockName}<br /></span>
              }
              {@getMaterialImage 1} {dock.api_item1}
              {@getMaterialImage 2} {dock.api_item2}
              {@getMaterialImage 3} {dock.api_item3}
              {@getMaterialImage 4} {dock.api_item4}
              {@getMaterialImage 7} {dock.api_item5}
            </Tooltip>
          else
            <span />
        }>
          <div className="panel-item kdock-item">
            <span className="kdock-name">{dockName}</span>
            <CountdownLabel dockIndex={i}
                            completeTime={dock.api_complete_time}
                            isLSC={isLSC}
                            isInUse={isInUse}
              />
          </div>
        </OverlayTrigger>
    }
    </div>

module.exports = KdockPanel
