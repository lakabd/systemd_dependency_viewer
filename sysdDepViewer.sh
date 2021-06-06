#!/bin/bash

LINK="plot.html"

tee -a <<EOL
                         .___
  _________.__. ______ __| _/
 /  ___<   |  |/  ___// __ | 
 \___ \ \___  |\___ \/ /_/ | 
/____  >/ ____/____  >____ | 
     \/ \/         \/     \/ Dependency Viewer. By @lakabd

EOL

echo -n "[+] Retrieving services..."
service_names=($(systemd-analyze plot | grep '\"left' | awk -F '>' '{print $2}'| awk -F '<' '{print $1}'| awk -F ' ' '{print $1}'))
#removing kernel and systemd from array
service_names=("${service_names[@]:1}")
service_names=("${service_names[@]:1}")
#removing svg legend keywords from array
unset service_names[${#service_names[@]}-1]
unset service_names[${#service_names[@]}-1]
unset service_names[${#service_names[@]}-1]
unset service_names[${#service_names[@]}-1]
unset service_names[${#service_names[@]}-1]
unset service_names[${#service_names[@]}-1]
echo "done !"

echo -n "[+] Html parsing..."
flag=0
echo "<!-- Systemd Dependency Viewer v1.0 -->" > $LINK
while IFS= read -r line
do
	echo "$line" | grep '<rect.*x="[0-9][0-9]' &> /dev/null
	if [ $? -eq 0 ]; then
		if [ $flag -eq 0 ]; then
			echo "</a><a style='cursor: pointer;' onclick='javascript:sysdDep(this);'>" >> $LINK
		fi
		echo $line >> $LINK
		flag=1
	else
		echo $line >> $LINK
		flag=0
	fi
done <<< $(systemd-analyze plot)

tee -a $LINK > /dev/null <<EOL
<script>
	function sysdDep(element){
		console.log(element.getElementsByClassName('left')[0].innerHTML.split(" ")[0]);
		service_name=element.getElementsByClassName('left')[0].innerHTML.split(" ")[0];
		if (document.getElementsByClassName(service_name)[0] != null){
			dotsrc=document.getElementsByClassName(service_name)[0].textContent;
		}
		else{
			alert(service_name + " have no dependency !")
			return;
		}
		var svg=Viz(dotsrc,"svg");
		console.log(svg);
		var tempDiv = document.createElement('div');
		tempDiv.innerHTML = svg;
		var svg_width=(parseInt(tempDiv.getElementsByTagName("svg")[0].getAttribute("width").split('pt')[0])*4.2)/3; //pt to px
		var svg_height=(parseInt(tempDiv.getElementsByTagName("svg")[0].getAttribute("height").split('pt')[0])*4.6)/3; //pt to px
		var legend= "<div style='margin: auto;text-align: center;'> \
					<span style='color:black'>Requires - </span> \
					<span style='color:DarkBlue'>Requisite - </span> \
					<span style='color:DarkGrey'>Wants - </span> \
					<span style='color:red'>Conflicts - </span> \
					<span style='color:green'>After - </span> \
					</div> \
					"
		var win = window.open("", "Systemd Dep By lakabd", "width="+svg_width+",height="+svg_height+","+"location=no,menubar=no,status=no,resizable=no");
		win.document.write(svg);
		win.document.write(legend);
		tempDiv.remove();
	}
</script>
<script src="https://lakabd.github.io/viz.js" type="text/javascript" charset="utf-8"></script>
EOL
echo "done !"
sleep 0.5

echo "[+] Retrieving dependencies (in DOT format) for:"
sleep 1
for service in "${service_names[@]}"
do	
	OUTPUT=$(systemd-analyze dot $service 2>/dev/null)
		if [ $? -eq 0 ]; then
			echo "<div class='$service' style='display: none'>" >> $LINK
			echo $OUTPUT >> $LINK
			echo "</div>" >> $LINK
			echo -e "\t -> $service"
		fi
done

echo "[+] $LINK created succesfully !"
