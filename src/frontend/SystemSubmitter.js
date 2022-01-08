import React, { Component } from 'react'

class SystemSubmitter1 extends Component {
    render() {
      return (
       <div>
        <h3>Request Audit</h3>
        <br></br>
        <form onSubmit={(event) => {
          
        
        }}>
           <input
              id="Request Audit"
              type="text"
              className="form-control"
              placeholder="IPFS link to system details and files"
              required />
        <input type="submit"  />
<br/>
        <input
              id="Bounty"
              type="text"
              className="form-control"
              placeholder="bounty"
              required />
        <input type="submit"  />
        <br/>

        <input
              id="Staking Window"
              type="text"
              className="form-control"
              placeholder="Time Window"
              required />
        <input type="submit"  />
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
