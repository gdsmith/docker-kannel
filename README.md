# docker-kannel
Kannel dockerized.

Simply kannel docker image. Mount your own conf files to use.

Usage with docker-compose:

	kannel:
      image: bulktrade/kannel:1.4.4
      ports:
        - 13013 # smsbox
        - 13000 # kannel admin
      #volumes:
      #  - "./kannel.conf:/etc/kannel/kannel.conf"
      #  - "./opensmppbox.conf:/etc/kannel/opensmppbox.conf"

Start container with docker-conpose: 
	
	docker-compose up -d
	
Start container with docker:

	docker run --rm bulktrade/kannel:1.5.0-trunk