<template lang="pug">
    chipnflip-layout(v-if="authorized")
      main
        .central-panel.container.bills
          .note-row Your bill:
          .bill-row
            .decrease
              .note
                .delta -20
                .date 10.07.2017
              .arrow: img(src="/images/arrow-down.png")
            .current
              .amount 150
            .increase
              .arrow: img(src="/images/arrow-up.png")
              .note
                .delta +170 #[br]
                .date 12.07.2017
          .note-currency-row credits
          .buttons-row
            button.button-solid Withdraw money
            button.button-solid Deposit money
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
