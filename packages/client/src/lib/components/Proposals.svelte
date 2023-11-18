<script lang="ts">
  import { components, systemCalls } from "$lib/stores"
  import { Has, runQuery, getComponentValueStrict } from "@latticexyz/recs";
  import IPFSString from "./IPFSString.svelte"
  import QuadraticVote from "./QuadraticVote.svelte"
  // import Upload from "./Upload.svelte"

  let proposals = []
  let executed = []
  
  // query for all named players at the center of the universe
  $: {
    if ($components && $components?.Proposal) {  
      const matchingEntities = runQuery([
        Has($components.Proposal)
      ])

      proposals = [...matchingEntities].map(ent => getComponentValueStrict($components?.Proposal, ent))
      executed = [...proposals].filter(prop => prop.executed)

      $components.Proposal.update$.subscribe(update => {
        const [next, previous] = update.value
    
      })
    }
  }

</script>

<h1>
  Current proposals
</h1>

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
        {proposal.systemName}
      </p>

      <div class="vote">
        <QuadraticVote />
      </div>
    </div>
  </div>
{/each}

<!-- List proposals here -->
<!-- <Upload /> -->

<style>
  .vote {
    display: flex;
    justify-content: space-between;
  }

  .vote {

  }

  .votes {
    display: flex;
    gap: .5rem;
  }

  .overflow {
    white-space: nowrap;
    width: 100%;
    overflow: hidden;

    text-overflow: ellipsis;
  }

  .proposer {
    word-wrap: break-word;
  }

  .vote button {
    width: 60px;
  }

  .card {
    padding: .5rem;
    background: #444;
    margin-bottom: 1rem;
  }
</style>

