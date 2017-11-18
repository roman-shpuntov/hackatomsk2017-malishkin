<template lang="pug">
    chipnflip-layout(v-if="authorized")
      main
        .central-panel.container.settings
          .aside Settings
          .content
            | Choose password
            form
              input.input-solid(type="password" name="password" placeholder="Your password")
              input.input-solid(type="password" name="password" placeholder="New password")
              input.input-solid(type="password" name="password" placeholder="Repeat new password")
              input.button-solid(type="submit" value="Save")
</template>
<script>
  import chipnflipLayout from "../components/chipnflip-layout.vue";

  export default {
    components: {chipnflipLayout},
    data: () => ({
      authorized: localStorage.token != undefined,
      username: null
    })
  }
</script>
