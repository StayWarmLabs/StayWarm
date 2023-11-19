<script lang="ts">
  import { systemCalls } from "$lib/stores"

  import * as PushAPI from '@pushprotocol/restapi';
  import { walletState } from "../metamask";
  import { encodeEntity } from "@latticexyz/store-sync/recs";


  let form: HTMLFormElement
  let loadingState = ""

  // TODO: use sendNotification function
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
      // TODO: modify title and body
      {notification: {title: 'Hello', body: 'World'}}
    )
  }


  const submit = async () => {
    const data = new FormData(form)
    let uri = ""

    loadingState = "Uploading propsal to IPFS"

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
      loadingState = "Persisting proposal"
      await $systemCalls.propose(data.get("address"), data.get("systemName"), uri)
    } catch (error) {
      console.error("Error creating proposal", error)
    } finally {
      loadingState = "Proposal made"
      form.reset()
      
      await new Promise(r => setTimeout(r, 2000));
      loadingState = ""
    }
    // create proposal
  }
</script>

<div class="new-proposal">
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
        <option value="BurnSystem">BurnSystem</option>
        <option value="GovernSystem">GovernSystem</option>
        <option value="JoinSystem">JoinSystem</option>
        <option value="SettleGameSystem">SettleGameSystem</option>
        <option value="SettleRoundSystem">SettleRoundSystem</option>
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
  {loadingState}
</div>

<div class="form-group">
  <h1>
    Current proposals
  </h1>
</div>


<style>
  .new-proposal {
    transition: opacity 0.2s ease;
  }
  .new-proposal,
  .form-group {
    display: flex;
    flex-direction: column;
    margin-bottom: 1rem;
  }
  textarea {
    font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  }

  .loading {
    opacity: 0.3;
  }
</style>