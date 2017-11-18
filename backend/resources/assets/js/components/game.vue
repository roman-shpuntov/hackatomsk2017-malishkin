<template>
  <div class="grid">
  </div>
</template>

<script>
  export default {
    mounted() {
      this.offerGame();
    },
    data: {
      channel: null
    },
    methods: {
      offerGame() {
        fetch("/api/v1/game-offer", {
          method: "POST",
          headers: {
            "Authorization": "Bearer " + localStorage.token,
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({
            gameType: "free",
            bet: 0
          })
        }).then((request) => request.json()).then((data) => {
          this.channel = data.channel;
        });
      }
    }
  }
</script>
