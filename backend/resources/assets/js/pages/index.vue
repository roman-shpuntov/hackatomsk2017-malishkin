<template lang="pug">
  .page-index.fullheight
    chipnflip-layout(v-if="authorized")
      main.start-the-game
        .user
          img(src="/images/avatar.png")
          | {{username}}
        a.button-solid(href="#/game") Start the game

    .unauthorized-variant.fullheight(v-else)
      img(src="/images/logo.png")
      form.authorize-form(method="post" @submit="authorize")
        input.input-rounded(type="email" name="email" placeholder="Your Email")
        input.input-rounded(type="password" name="password" placeholder="Password")
        input.button-light(type="submit" value="Log in")
        a.register-link(href="#/register") Register
</template>
<script>
  import chipnflipLayout from "../components/chipnflip-layout.vue";

  export default {
    components: {chipnflipLayout},
    data: () => ({
      authorized: localStorage.token != undefined,
      username: localStorage.user_name
    }),
    methods: {
      authorize(event) {
        fetch("/api/v1/login", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({
            email: event.target.email.value,
            password: event.target.password.value
          })
        }).then((request) => request.json()).then((data) => {
          localStorage.token = data.token;
          localStorage.user_id = data.user_id;
          localStorage.user_name = data.name;
          this.authorized = true;
        });

        event.preventDefault();
      }
    }
  }
</script>
