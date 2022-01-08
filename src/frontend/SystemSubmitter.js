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
        </form>
        <br></br>
        
        <h3>Bounty</h3>
        <form onSubmit={(event) => {
          
        
        }}>
           <input
              id="Bounty"
              type="text"
              className="form-control"
              placeholder="bounty"
              required />
        <input type="submit"  />
        </form>
        <br></br>
        
        <h3>Staking Window</h3>
        <form onSubmit={(event) => {
          
        
        }}>
           <input
              id="Staking Window"
              type="text"
              className="form-control"
              placeholder="staking window"
              required />
        <input type="submit"  />
        </form>
        </div>
      )}}

      export const SystemSubmitter = SystemSubmitter1
