import React, { Component } from 'react'
import { ethers } from "ethers";



class SystemSubmitter1 extends Component {
    provider = new ethers.providers.Web3Provider(window.ethereum)

    constructor(props) {
        super(props);
        this.state = {IPFS: ''};
        this.state = {TimeWindow: ''};
        this.state = {StakingAmount: ''};
      }
 // temp =  this.state.StakingAmount;
   
  render() {
      return (
       <div>
        <h3>Request Audit</h3>
        <br></br>
        <p>StakingAmount : {this.state.StakingAmount}</p>
        <br></br>

        <form onSubmit={(event) => {
                event.preventDefault()

               this.setState({IPFS: event.target[0].value})
               this.setState({TimeWindow: event.target[1].value})
               this.setState({StakingAmount: event.target[2].value});
               
        }}>
           <input
              id="Request Audit"
              type="text"
              className="form-control"
              placeholder="IPFS link to system details and files"
              required />
<br/>
        

        <input
              id="Staking Window"
              type="text"
              className="form-control"
              placeholder="Time Window"
              required />
        <br/>

        <input
              id="RepStakeAmount"
              type="text"
              className="form-control"
              placeholder="RepStakeAmount"
              required />
        <input type="submit"  />
        <br/>

        </form>
        <br></br>
        
       
        </div>
      )}}

      export const SystemSubmitter = SystemSubmitter1
