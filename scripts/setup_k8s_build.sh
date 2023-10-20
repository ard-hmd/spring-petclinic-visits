# Install Java (OpenJDK)
yum install java-11-amazon-corretto -y
yum install java-11-amazon-corretto-devel -y
echo $JAVA_HOME
export JAVA_HOME=`java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' `
echo $JAVA_HOME


# Install Maven (tool for Java project management)
wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
yum install -y apache-maven

# Install Git
yum install git -y
