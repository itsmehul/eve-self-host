import { defaultBackend, defineSandbox } from "eve/sandbox";

/**
 * Self-host sandbox selection: Docker → microsandbox → just-bash.
 * Never pins vercel() so production does not create hosted Vercel sandboxes.
 */
export default defineSandbox({
  backend: defaultBackend({
    docker: { networkPolicy: "deny-all" },
    microsandbox: { networkPolicy: "deny-all" },
  }),
});
