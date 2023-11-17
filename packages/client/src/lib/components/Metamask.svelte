<script>
  import { MetaMaskStore, isMetaMaskPresent, walletState } from "../metamask";
  import { onMount } from "svelte";

  export const { connect, init } = MetaMaskStore();

  onMount(() => {
    init();
  });
</script>


{#if $isMetaMaskPresent}
  {#if Boolean($walletState.account)}
    <p>{$walletState.account}</p>
    <slot></slot>
  {:else}
    <button on:click={connect}>Connect Wallet</button>
  {/if}
{:else}
  <p>Metamask not found. Please install MetaMask</p>
{/if}