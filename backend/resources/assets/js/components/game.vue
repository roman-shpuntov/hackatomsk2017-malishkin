<template>
  <div class="page-game">
    <div class="grid" v-if="game_info_fetched">
      <div class="row" v-for="row in game_info.snapshot.field">
        <div class="cell" v-for="playerIndex in row">
          <div class="check">{{playerIndex}}</div>
        </div>
      </div>
    </div>
    <div v-if="!game_info_fetched">
      No available games...
    </div>
  </div>
</template>

<script>
  import Pusher from "pusher-js";
  import Echo from "laravel-echo";

  window.echo = new Echo({
    broadcaster: "pusher",
    key: window.pusherKey,
    cluster: "eu",
    encrypted: true
  });

  export default {
    mounted() {
      this.offerGame();
    },
    data: () => ({
      channel: null,
      game_info: {},
      game_info_fetched: false
    }),
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
            type: "free",
            bet: 0
          })
        }).then((request) => request.json()).then((data) => {
          this.channel = data.channel;

          echo.channel(data.channel).listen(".offer-accepted", (event) => {
            this.game_info = event.game_info;
            this.game_info_fetched = true;
          });

          if (data.game_info) {
            this.game_info = data.game_info;
            this.game_info_fetched = true;
          }
        });
      }
    }
  }
</script>
