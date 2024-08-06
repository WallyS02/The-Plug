<script lang="ts">
  import Router from "svelte-spa-router";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import AccountPanel from "./routes/AccountPanel.svelte";
  import Register from "./routes/Register.svelte";
  import Login from "./routes/Login.svelte";
  import RequestMeeting from "./routes/RequestMeeting.svelte";
  import PlugPanel from "./routes/PlugPanel.svelte";
  import Navbar from "./lib/Navbar.svelte";
  import Footer from "./lib/Footer.svelte";
  import MeetingPanel from "./routes/MeetingPanel.svelte";
  import DrugEdit from "./routes/DrugOfferEdit.svelte";
  import LocationEdit from "./routes/LocationEdit.svelte";

  const routes = {
    '/': Home,
    '/register': Register,
    '/login': Login,
    '/account/:id': AccountPanel,
    '/plug/:id': PlugPanel,
    '/drug-offer/:id': DrugEdit,
    '/location/:id': LocationEdit,
    '/meeting/:id': MeetingPanel,
    '/request-meeting/:plug-id': RequestMeeting,
    '*': NotFound,
  }
</script>

<style>
  @import 'tailwindcss/tailwind.css';
</style>

<main class="p-4">
  <Navbar/>
  <Router {routes} />
  <Footer/>
</main>
