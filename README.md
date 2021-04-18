# Building_DEX

<h2> Building my own Decentralized Exchange (DEX) </h2>
  
<h3> This project will follow multiple steps and be built from the ground up </h3>

<p> This project utilizes the openzeppelin library for ERC20 Tokens </p>

<ol> Steps to follow
  <li> Build a Wallet </li>
  <li> Ensure wallet's safety </li>
  <li> Improve migrations file </li>
  <li> Creating a DEX </li>
  <li> Wallet Tests </li>
  <li> Limit Order Tests </li>
  <li> Market Order Tests </li>
</ol>
  
<p> NOTE: This DEX uses order books which is viewed as old technology in creating DEXs </p>

<h3> Improving DEX </h3>
<p> The main idea is to create a DEX that protects smaller traders (trading with a small amount of money) from big traders. This can be achieved through:
<ul>
  <li> Having divisions within the platform based on the total ETH balance of an address (This includes the value of tokens owned in ETH) </li>
  <li> The lowest division will have a maximum value of ETH they are allowed to trade </li>
  <li> The highest division will have a minimum value of ETH they are allowed to trade </li>
  <li> Divisions in between will have both minimum and maximum value of ETH they are allowed to trade </li>

<p> I was thinking of adding tokens only accessible to lower divisions to protect them from massive pump-and-dump moves from a big trader </p>

<h3> Introducing Staking </h3>
<p> Now that the smaller traders are protected, we still want our big traders to keep using the platform by allowing them to stake their tokens (incentives to big traders) </p>
<ul>
  <li> Introduce staking privileges once a certain division is reached </li>
  <li> Add the percentage earned by staking when moving up on divisions </li>
</ul>
