# Break on first line (Please keep this line at the top of this file)
debugger if dbg.h.brk?.isEnabled()

{ROOT, EXROOT, _, $, $$, React, ReactDOM} = window
{config, toggleModal} = window
fs = require 'fs-extra'
path = require 'path-extra'
{Provider} = require 'react-redux'

__ = window.i18n.others.__.bind(i18n.others)
__n = window.i18n.others.__n.bind(i18n.others)

# Disable OSX zoom

require('electron').webFrame.setZoomLevelLimits(1, 1)

# Hackable panels
window.hack = {}

# Plugin manager
window.PluginManager = require './services/plugin-manager'

# Alert functions
require './services/alert'

# Module path
require('module').globalPaths.push(path.join(ROOT, "node_modules"))

# poi menu
require './components/etc/menu'

# Create redux store and add event listener
{store} = require './createStore'

# Main tabbed area
ControlledTabArea = require './tabarea'

{PoiAlert} = require './components/info/alert'
{PoiMapReminder} = require './components/info/map-reminder'
{PoiControl} = require './components/info/control'
{ModalTrigger} = require './components/etc/modal'

# Custom css injector
CustomCssInjector = React.createClass
  render: ->
    cssPath = path.join window.EXROOT, 'hack', 'custom.css'
    fs.ensureFileSync cssPath
    <link rel='stylesheet' id='custom-css' href={cssPath} />

ReactDOM.render(
  <Provider store={store}>
    <PoiControl />
  </Provider>,
  $('poi-control'))
ReactDOM.render(
  <Provider store={store}>
    <PoiAlert id='poi-alert' />
  </Provider>,
  $('poi-alert'))
ReactDOM.render(
  <Provider store={store}>
    <PoiMapReminder id='poi-map-reminder'/>
  </Provider>,
  $('poi-map-reminder'))
ReactDOM.render <ModalTrigger />, $('poi-modal-trigger')
ReactDOM.render(
  <Provider store={store}>
    <ControlledTabArea />
  </Provider>,
  $('poi-nav-tabs'))
ReactDOM.render <CustomCssInjector />, $('poi-css-injector')
