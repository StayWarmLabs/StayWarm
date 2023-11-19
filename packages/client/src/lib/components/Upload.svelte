<script lang="ts">
  // import * as PushAPI from '@pushprotocol/restapi';
  import { fly } from "svelte/transition"
  import { systemCalls } from "$lib/stores"
  import { createEventDispatcher } from "svelte"
  import { walletState } from "../metamask";
  import { encodeEntity } from "@latticexyz/store-sync/recs";

  export let adding = true

  let form: HTMLFormElement
  let loadingState = ""


  const onKeyDown = (e) => {
    if (e.key === "Escape") dispatch("close")
  }

  const dispatch = createEventDispatcher()

  const sendNotification = async () => {
    const address = encodeEntity({address: "address"}, { address: $walletState.account })

    const proposer = await PushAPI.initizalize(address, {env: 'staging'})

    // const inboxNotifications = await userAlice.notification.list('INBOX')
    // const spamNotifications = await userAlice.notification.list('SPAM')

    // Ethereum sepolia network
    const pushChannelAddress = '0x1fBba7Fa7741CF7eBB0415E4d29A271Cb1D0AfDe';

    await proposer.notification.subscribe(
      'eip155:11155111:${pushChannelAddress}'
    )

    const broadcastNotifications = await proposer.channel.send(
      ['*'],
      {notification: {title: 'Hi', body: 'Proposal made!'}}
    )
  }


  const submit = async () => {
    const data = new FormData(form)
    let uri = ""

    loadingState = "Uploading propsoal to IPFS"

    try {
      const cid = await fetch("/api", { method: "POST", body: data })
      const str = await cid.text()
      uri = `ipfs://${str}`
    } catch (error) {
      console.error("Error", error)
    } finally {
      loadingState = "Uploaded proposal to IPFS"
    }

    try {
      await sendNotification()
    } catch (error) {
      console.error("Error sending notification", error)
    }

    try {
      loadingState = "Persisting proposal"
      await $systemCalls.propose(data.get("address"), data.get("systemName"), uri)
    } catch (error) {
      console.error("Error creating proposal", error)
    } finally {
      loadingState = "Proposal made"
      form.reset()
      adding = false
      
      await new Promise(r => setTimeout(r, 2000));
      loadingState = ""

      dispatch("close")
    }
    // create proposal
  }
</script>

<svelte:window on:keydown={onKeyDown} />

<div transition:fly={{ x: 100 }} class="new-proposal">
  <div class="form-group">
    <h1>
      New proposal
    </h1>
  </div>
  <form class:loading={loadingState !== ""} bind:this={form} on:submit|preventDefault={submit}>
    <div class="form-group">
      <label for="address">
        Contract Address
      </label>
      <input disabled={loadingState !== ""} placeholder="contract address" type="text" name="address" id="">
    </div>
    <div class="form-group">
      <label for="systemName">
        System Name
      </label>
      <select disabled={loadingState !== ""} name="systemName">
        <!-- BurnSystem, GovernSystem, JoinSystem, SettleGameSystem, SettleRoundSystem -->
        <option value="Burn">Burn</option>
        <option value="Govern">Govern</option>
        <option value="Join">Join</option>
        <option value="SettleGame">SettleGame</option>
        <option value="SettleRound">SettleRound</option>
      </select>
    </div>
    <div class="form-group">
      <label for="text">
        Motivation
      </label>
      <textarea disabled={loadingState !== ""} placeholder="Proposal" type="text" name="text" id="" rows="10"></textarea>
    </div>
    <input type="submit" value="Submit proposal">
  </form>
  <p>
    {loadingState}
  </p>
</div>

<style>

  select,
  input,
  textarea {
    font-size: 16px;
  }
  textarea {
    padding: 0.5rem .5rem;
  }
  .new-proposal {
    transition: opacity 0.2s ease;
    position: fixed;
    top: 0;
    right: 0;
    height: 100vh;
    width: 50vw;
    z-index: 999;
    background: black;
    padding: 1rem;
  }
  .new-proposal,
  .form-group {
    display: flex;
    flex-direction: column;
    margin-bottom: 1rem;
  }


  .loading {
    opacity: 0.3;
  }

  @media (prefers-color-scheme : light) {
    .new-proposal {
      background: white;
    }
  }
</style>