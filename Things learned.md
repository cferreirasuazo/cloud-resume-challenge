You need to configure next.config.mjs for build static pages

You use serve out for view static pages

you need to specify the environment in githubactions in order to use secrets ( if they are in an env)

When pushing terraform files, make sure to not include .terraform

if you are going to use aws crdentials outside Aws, make sure to specify it when creating the credentials that they are going tio be used outside like in github actions
