$packages        = hiera('site::packages',[])
ensure_packages($packages) # Requires stdlib but is safer
