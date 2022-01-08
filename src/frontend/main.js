import React, { Component } from 'react'
import ReactDOM from 'react-dom'

import 'normalize.css'
import './main.sass'
import { Greeter } from './greet.js'
import { SystemSubmitter } from './SystemSubmitter.js'


const Main = () => (

  <div id='Main'>    
<Greeter/>
<SystemSubmitter/>

</div>

)
ReactDOM.render(<Main/>, document.getElementById('root'))