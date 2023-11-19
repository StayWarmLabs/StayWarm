<script>
  import { padWithZero } from "$lib/utils"
  import { fly } from "svelte/transition"
  import { timeLeft as timeLeftStore } from "$lib/stores"

  let timeLeft = {
      hours: 0,
      minutes: 0,
      seconds: 0
  };

  const calculateTimeLeft = (v) => {
      if ($timeLeftStore <= 0) {
          return {
              hours: 0,
              minutes: 0,
              seconds: 0
          };
      }

      return {
          hours: padWithZero(Math.floor((v / (60 * 60)) % 24)),
          minutes: padWithZero(Math.floor((v / (60)) % 60)),
          seconds: padWithZero(Math.floor((v) % 60))
      };
  };

  $: timeLeft = calculateTimeLeft($timeLeftStore)

</script>

{#if timeLeft.hours === 0 && timeLeft.minutes === 0 && timeLeft.seconds === 0}
  <!-- Started -->
{:else}
  <div in:fly={{ y: -20 }} class="">
    <p class="counter">
      {timeLeft.hours}:{timeLeft.minutes}:{timeLeft.seconds}
    </p>
  </div>

  <div class="gradient" />
{/if}

<style>
  .counter {
    font-family: "Fira Code", monospaced;
    font-weight: bold;
    color: orangered;
    font-size: 80px;
    margin: 0;
    padding: 0.5rem 3rem;
    border: 4px solid orangered;
    background-color: rgba(255, 255, 255, 0.8);
    margin-bottom: 1rem;
    border-radius: 5px;
  }

  .gradient {
    position: fixed;
    left: 50vw;
    top: 50vh;
    width: 100vw;
    height: 100vw;
    /* background: radial-gradient(circle, rgba(255,104,0,1) 0%, rgba(62,42,42,1) 10%, rgba(255,104,0,0) 60%); */
    transform: translate(-50%, -50%);
    z-index: -1;;
  }
</style>
