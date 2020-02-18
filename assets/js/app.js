// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import 'bootstrap';
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

// Hooking ContentEditable for update event
//
let Hooks = {};


Hooks.RowDnD = {
  mounted: function() {
    this._dragstartListener = e => {
      e.stopPropagation();
      this.el.style.opacity = "0.6";
      e.dataTransfer.effectAllowed="move";
      e.dataTransfer.setData( "row_id", this.el.id);
    };
    this._dragendListener = e => {
      e.stopPropagation();
      this.el.className = "mdl-draggable-row";
      this.el.style.opacity = "1.0";
    };
    this._dragoverListener = e => {
      e.stopPropagation();
      this.el.className = "mdl-dragover-row";
      e.preventDefault();
    };
    this._dragleaveListener = e => {
      e.stopPropagation();
      e.preventDefault();
      this.el.className = "mdl-draggable-row";
    };
    this._dropListener = e => {
      e.stopPropagation();
      let payload = {};
      payload.drag_row = e.dataTransfer.getData( "row_id");
      payload.drop_row = this.el.id;
      this.pushEvent( "move_row", payload);
    };
    this.el.addEventListener( "dragstart", this._dragstartListener);
    this.el.addEventListener( "dragend", this._dragendListener);
    this.el.addEventListener( "dragover", this._dragoverListener);
    this.el.addEventListener( "dragleave", this._dragleaveListener);
    this.el.addEventListener( "drop", this._dropListener);
  },
  destroyed: function() {
    if( this._dragstartListener) this.el.removeEventListener( "dragstart", this._dragstartListener);
    if( this._dragendListener) this.el.removeEventListener( "dragend", this._dragendListener);
    if( this._dragoverListener) this.el.removeEventListener( "dragover", this._dragoverListener);
    if( this._dragleaveListener) this.el.removeEventListener( "dragleave", this._dragleaveListener);
    if( this._dropListener) this.el.removeEventListener( "drop", this._dropListener);
  }
};

Hooks.RowFunctions = {
  updated: function() {
    let id = this.el.dataset.move_focus;
    if (id != null && id !== "") {
      let el = document.getElementById( id);
      move_focus( el);
    }
  }
};

function move_focus( el)  {
  console.info( "move_focus:");
  console.info( el.id);
  el.focus();
  console.info( document.activeElement.id);
}


// let liveSocket = new LiveSocket("/live", Socket)
let liveSocket = new LiveSocket( "/live", Socket, { hooks: Hooks});
// let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
// let liveSocket = new LiveSocket("/live", Socket, { params: {_csrf_token: csrfToken}, hooks: Hooks});
liveSocket.connect();
