import React from 'react'
import ReactDOM from 'react-dom'

import 'normalize.css'
import './main.sass'

const Main = () => (
  <div id='Main'>
    <h1>Ethereum-Audit</h1>
  

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
)

ReactDOM.render(<Main/>, document.getElementById('root'))