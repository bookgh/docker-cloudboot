# docker-cloudboot

Thanks to [anjia0532](http://idcos.github.io) & [云霁科技](http://idcos.com/)

## use 

	git clone https://github.com/n3uz/docker-cloudboot.git 
	cd docker-cloudboot
	chmod +x cloudact2/delay_cloudact2.sh cloudboot/delay_cloudboot.sh	
	
修改 docker-compose.yml 中IP={YOUR SERVER IP}
	
	docker-compose up -d 
	
确保服务器上80 3306 53 等端口未被占用，最好单独一台服务器。

http://{YOUR SERVER IP} username:`admin` ,password:`admin`
