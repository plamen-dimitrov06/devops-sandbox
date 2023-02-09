download.get.docker:
  cmd.run:
    - name: curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    
install.docker:
  cmd.run:
    - name: bash /tmp/get-docker.sh
    
run.docker.service:
  service.running:
    - name: docker
    
modify.user:
  user.present:
    - name: vagrant
    - groups: 
      - docker

install.docker.py:
  pip.installed: 
    - name: docker >= 5 , < 6
    - upgrade: True