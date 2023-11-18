<script lang="ts">
  import { components, entities } from "$lib/stores"
  import { getComponentValue } from "@latticexyz/recs";
  import { singletonEntity } from "@latticexyz/store-sync/recs";

  $: {
    if ($components?.Config) {
      console.log($components?.Config)
      console.log (getComponentValue($components?.Config, singletonEntity));
    }
  }
</script>
