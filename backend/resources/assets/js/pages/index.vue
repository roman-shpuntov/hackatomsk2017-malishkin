<template lang="pug">
  .page-index.fullheight
    .authorized-variant.fullheight(v-if="authorized")
      header
        .container
          a.homepage-link(href="#/"): img(src="/images/home.png" alt="home")
          .tabs
            .tab: a(href="#/credits") {{creditAmount}} credits
            .tab: a(href="#/howtoplay") How to play
            .tab: a(href="#/settings") Settings
            .tab: a(href="#/logout") Log out&nbsp;&nbsp;#[img(src="/images/log-out.png")]
      main.start-the-game
        .central-part.fullheight
          .user
            img(src="/images/avatar.png")
            | {{username}}
          button.button-solid Start the game
      footer
        .container.fullheight
          .brand Chip'n'Flip
          .links
            a(href="#/credits") Credits
            a(href="#/howtoplay") How to play
            a(href="#/settings") Settings
            a(href="#/terms") Terms and conditions
          .social-icons
            .social-icon: img(src="/images/social/vk.png")
            .social-icon: img(src="/images/social/f.png")
            .social-icon: img(src="/images/social/ok.png")
            .social-icon: img(src="/images/social/g+.png")
            .social-icon: img(src="/images/social/twitter.png")
          .phone +7 (800) 888-98-88

    .unauthorized-variant.fullheight(v-else)
      form.authorize-form(method="post" @submit="authorize")
        input.input-rounded(type="email" name="email" placeholder="Your Email")
        input.input-rounded(type="password" name="password" placeholder="Password")
        input.button-light(type="submit" value="Log in")
        a.register-link(href="#/register") Register
</template>
<script>
  export default {
    data: () => ({
      authorized: localStorage.token != undefined,
      creditAmount: 0
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
          this.authorized = true;
        });

        event.preventDefault();
      }
    }
  }
</script>
