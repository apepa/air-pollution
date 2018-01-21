import os

URL_FILE = "listed_urls"
FULL_WEB_PATH = "http://archive.luftdaten.info/"
FOLDER = "/Users/pgencheva/scrapped_data/"

bg_sensors = set(open('/Users/pgencheva/Downloads/sensor_ids').read().split("\n"))

allowed = 0
with open(URL_FILE) as out:
	lines = out.read()
	lines = lines.split("\n")

	for line in reversed(lines):
		folder = line.split("\t")[1]
		for sensor_id in bg_sensors:
			os.system("wget -np -nH -P " + FOLDER + " -e robots=off --cut-dirs 3 --random-wait " + FULL_WEB_PATH + folder+ folder.strip('/')+"_sds011_sensor_{}.csv".format(sensor_id))
		print("=============== processed directory {}".format(folder))