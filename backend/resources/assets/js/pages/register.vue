<template lang="pug">
  .page-register.fullheight
    .unauthorized-variant.fullheight
      img(src="/images/logo.png")
      form.authorize-form(method="post" @submit="authorize")
        input.input-rounded(type="email" name="email" placeholder="Your Email")
        input.input-rounded(type="name" name="name" placeholder="Your name")
        input.input-rounded(type="password" name="password" placeholder="Password")
        input.button-light(type="submit" value="Sign up")
</template>

<script>
  export default {
    methods: {
      authorize(event) {
        fetch("/api/v1/user", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({
            name: event.target.username.value,
            email: event.target.email.value,
            password: event.target.password.value
          })
        }).then((request) => request.json()).then((data) => {
          localStorage.token = data.token;
          localStorage.user_id = data.user_id;
          localStorage.user_name = data.name;
          this.$router.push("/");
        });

        event.preventDefault();
      }
    }
  }
</script>
