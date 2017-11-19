<template lang="pug">
  .page-game
    .row-avatars
      .avatar.avatar-left
        img(src="/images/avatar.png", alt="avatar")
        .username(v-bind:class="{ active: game_info && game_info.snapshot.turn_user_id == user_id}") {{user_name}}
      .bet
        img(src="/images/cup.png")
        | 150 credits
      .avatar.avatar-right
        img(v-if="game_info_fetched" src="/images/avatar.png", alt="avatar")
        img(v-else src="/images/searching.png", alt="searching")

        .username(v-if="game_info_fetched" v-bind:class="{ active: game_info.snapshot.turn_user_id == opponent.user_id}") {{opponent.name}}
        .username(v-else) Search...

    .row-grid
      .grid
        .row(v-for="(row, y) in field_reversed")
          .cell(v-for="(user_id, x) in row" @click="onCellClick" :data-coords-x="x" :data-coords-y="y")
            .check.first-check(v-if="user_id != 0 && user_id == game_info.users[0].user_id")
            .check.second-check(v-if="user_id != 0 && user_id == game_info.users[1].user_id")
    .row-buttons
      button.button-solid Cancel the game
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
      game_info: {
        snapshot: {
            field: [
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0]
            ]
        }
      },
      channel: "game-wYhtkf",
      game_info_fetched: false,
      user_name: localStorage.user_name,
      user_id: localStorage.user_id,
      moveFrom: null
    }),
    computed: {
      field_reversed() {
        return this.game_info.snapshot.field.reverse();
      },
      opponent() {
        return (
          this.game_info.users[0].user_id == localStorage.user_id ? this.game_info.users[1] : this.game_info.users[0]
        );
      }
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
      },
      onCellClick(event) {
        if (event.target.classList.contains("check")) {
          this.moveFrom = {
            x: parseInt(event.currentTarget.dataset.coordsX),
            y: parseInt(event.currentTarget.dataset.coordsY)
          }
        } else {
          let moveTo = {
            x: parseInt(event.currentTarget.dataset.coordsX),
            y: parseInt(event.currentTarget.dataset.coordsY)
          };
          let moveFrom = this.moveFrom;
          this.moveFrom = null;

          fetch("/api/v1/step", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            },
            body: JSON.stringify({
                "user_id": this.user_id,
                "game_id": this.game_info.game_id,
                "game_key": this.game_info.game_key,
                "from": `${6 - moveFrom.y}:${moveFrom.x}`,
                "to": `${6 - moveTo.y}:${moveTo.x}`
            })
          }).then((request) => request.json()).then((data) => {
            if (data.snapshot) {
              this.game_info.snapshot = data.snapshot;
              console.log(data.snapshot.turn_user_id);
            }
          });
        }
      }
    }
  }
</script>
