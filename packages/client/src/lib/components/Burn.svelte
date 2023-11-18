<script lang="ts">
  import { components, entities } from "$lib/stores"
  import { getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
  import { singletonEntity } from "@latticexyz/store-sync/recs";

  // console.log(singletonEntity)

  $: {
    if ($components?.Config) {
      $components?.Config.update$.subscribe(update => {
        console.log(update)
      })
      // console.log($components?.Config)
      // console.log(getComponentValue($components?.Config, singletonEntity));
      // console.log(getComponentValue($components?.Config, $components?.Config.id))
    }
  }

  $: {
    if ($components?.Config) {}
    console.log($entities[$components?.Config.id])
  }
</script>
