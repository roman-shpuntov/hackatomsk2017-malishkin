<template lang="pug">
  .page-game
    .row-avatars
      .avatar.avatar-left
        img(src="/images/avatar.png", alt="avatar")
        .username {{username}}
      .bet
        img(src="/images/cup.png")
        | 150 credits
      .avatar.avatar-right
        img(v-if="game_info_fetched" src="/images/avatar.png", alt="avatar")
        img(v-else src="/images/searching.png", alt="searching")

        .username(v-if="game_info_fetched") {{game_info.users[0].name}}
        .username(v-else) Search...

    .row-grid
      .grid
        .row(v-for="row in game_info.snapshot.field")
          .cell(v-for="user_id in row")
            .check.first-check(v-if="user_id == game_info.users[0].user_id")
            .check.second-check(v-if="user_id == game_info.users[1].user_id")
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
        game_id: 61,
        prize: 0,
        users: [
            {
              user_id: 2,
              name: "user1"
            },
            {
              user_id: 3,
              name: "yernende"
            }
        ],
        snapshot: {
            turn_user_id: 3,
            field: [
              [2, 0, 0, 0, 0, 0, 3],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0],
              [3, 0, 0, 0, 0, 0, 2]
            ]
        }
      },
      channel: "game-wYhtkf",
      game_info_fetched: false,
      username: localStorage.name
    }),
    methods: {
      offerGame() {
        return;
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
            console.log(this.game_info);
          });

          if (data.game_info) {
            this.game_info = data.game_info;
            this.game_info_fetched = true;
            console.log(this.game_info);
          }
        });
      }
    }
  }
</script>
