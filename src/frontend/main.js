import React, { Component } from 'react'
import ReactDOM from 'react-dom'

import 'normalize.css'
import './main.sass'
import { Greeter } from './greet.js'
import { SystemSubmitter } from './SystemSubmitter.js'



class main extends Component {
 
  constructor(props) {
    super(props);
    this.state = {IPFS: ''};
    this.state = {TimeWindow: ''};
    this.state = {StakingAmount: ''};
  }
  render() {
  return (
  <div>  
  <Greeter></Greeter>
  <SystemSubmitter></SystemSubmitter>
</div>

  )}}
  export const Main1 = main
 
ReactDOM.render(<Main1 />, document.getElementById('root'))