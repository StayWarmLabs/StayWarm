<script lang="ts">
	import { range } from '$lib/math';
	import { timeLeft, config } from '$lib/stores';

	let blendWithNext = true;
	const START_FRAME = 10;
	const END_FRAME = 29;

	let value = 0;

	$: completeValue = range(0, $config?.roundTimeLength, START_FRAME, END_FRAME - 1, $timeLeft); // there are 29, but algo will round up
	$: opacity = completeValue - Math.floor(completeValue);

	$: bottomSource = Math.floor(completeValue);
	$: topSource = Math.ceil(completeValue);

	$: console.log('completeValue:', completeValue);

</script>

<div class="background">
	<!-- <div class="control">
    <p style:color="black">
      {completeValue}
    </p>
    <input type="range" name="value" id="value" bind:value min={0} max={100}>
  </div> -->

	<img style:opacity class="bg top" src="/background/{topSource}.png" alt="STAYWARM" />
	<img class="bg" src="/background/{bottomSource}.png" alt="STAYWARM" />
</div>

<style>
	.background {
		position: fixed;
		width: 100vw;
		height: 100vh;
		overflow: hidden;
		inset: 0;
		z-index: 0;
	}
	.bg {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		background-size: cover;
		background-position: center;
		image-rendering: pixelated;
		filter: sharpen(200);
	}

	.bg.top {
		z-index: 1;
	}

	.control {
		position: fixed;
		width: 200px;
		bottom: 0;
		left: 50%;
		transform: translate(-50%, 0);
		z-index: 20;
	}
</style>
