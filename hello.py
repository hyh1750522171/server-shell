import json
import subprocess
import xmltodict

def load_json(xml):
    json = xmltodict.parse(xml)
    return json



def execute_command(command):
    result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.stdout.decode('utf-8')


def return_data(command):
    try:
        xml_output = execute_command(command)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        xml_output = ""
    return xml_output
# 显卡信息
# Command to fetch XML data from nvidia-smi
# nvidia_smi_command = "nvidia-smi -x -q"
# print(json.dumps(load_json(return_data(nvidia_smi_command))))
# CPU信息
# cpu_command = 'lscpu -J'
# print(return_data(cpu_command))

# AMD显卡信息
cpu_command = 'lshw -C display -json'
print(return_data(cpu_command))
# 内存

# free -h | awk 'NR==2{print "{\"total_mem\":\""$2"\", \"used_mem\":\""$3"\", \"free_mem\":\""$4"\", \"shared_mem\":\""$5"\", \"buff_cache_mem\":\""$6"\", \"available_mem\":\""$7"\"}"}'

# free_command = "free -h | awk 'NR==2{print \"{\\\"total_mem\\\":\\\"\"$2\"\\\", \\\"used_mem\\\":\\\"\"$3\"\\\", \\\"free_mem\\\":\\\"\"$4\"\\\", \\\"shared_mem\\\":\\\"\"$5\"\\\", \\\"buff_cache_mem\\\":\\\"\"$6\"\\\", \\\"available_mem\\\":\\\"\"$7\"\\\"}\"}'"

# print(return_data(free_command))


# # df -h | tail -n +2 | awk '{print "\""$1"\":{\"filesystem\":\""$2"\",\"size\":\""$3"\",\"used\":\""$4"\",\"avail\":\""$5"\",\"use\":\""$6"\",\"mounted\":\""$7"\"},"}' | sed '$s/,$//' | awk 'BEGIN{print "{"}{print $0}END{print "}"}'


# jq_command = "df -h"

# # jq_output = subprocess.run(jq_command, shell=True, check=True, input=df_output.stdout, stdout=subprocess.PIPE, universal_newlines=True)

# ip_j_command = 'ip -j addr show'
# print(return_data(ip_j_command))

# ip_s_command = 'ip -s -j -h link show'
# print(return_data(ip_s_command))