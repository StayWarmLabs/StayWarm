<script lang="ts">
  import { components, systemCalls } from "$lib/stores"
  import { Has, runQuery, getComponentValueStrict } from "@latticexyz/recs";
  import { createEventDispatcher } from "svelte"
  import IPFSString from "./IPFSString.svelte"
  import QuadraticVote from "./QuadraticVote.svelte"
  import Upload from "./Upload.svelte"

  const dispatch = createEventDispatcher()

  let proposals = []
  let adding = false
  
  // query for all named players at the center of the universe
  $: {
    if ($components && $components?.Proposal) {  
      const matchingEntities = runQuery([
        Has($components.Proposal)
      ])

      proposals = [...matchingEntities].map(ent => getComponentValueStrict($components?.Proposal, ent))

      $components.Proposal.update$.subscribe(() => {
        const matchingEntities2 = runQuery([
          Has($components.Proposal)
        ])

        proposals = [...matchingEntities2].map(ent => getComponentValueStrict($components?.Proposal, ent))
      })
    }
  }

</script>

<div class="">
  <h1>
    Current proposals
  </h1>
  
  {#if proposals.length > 0}
    {#each proposals as proposal, i (proposal.proposer + i)}
      <div class="card">
        <div class="form-group">
          <p class="proposer">
            {proposal.proposer} proposed:
          </p>
          <p>
            <IPFSString url={proposal.uri} />
          </p>
          <p class="overflow">
            <a href="https://etherscan.io/address/{proposal.implAddr}" class="implementation">
              {proposal.implAddr}
            </a>
          </p>
          <p class="system">
            Overwrites: {proposal.systemName}
          </p>
  
          <div class="vote">
            <QuadraticVote {proposal} />
          </div>
        </div>
      </div>
    {/each}
  {:else}
    <p>
      No active proposals
    </p>
  {/if}

  <button class="add" on:click={() => dispatch("add")}>
    +
  </button>

</div>

<style>
  .add {
    position: absolute;
    bottom: 30px;
    right: 30px;
    width: 50px;
    height: 50px;
    border-radius: 100%;
    z-index: 9999;
  }
</style>
