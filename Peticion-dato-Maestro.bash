curl --location --request GET 'https://api.pilotsolution.net/v1/masters/read.php' \
--header 'content-type: application/json' \
--data-raw ' {
	"data": {
		"master": "workshop_model"	
	},
	"header": {
		"FlowName": "masterdata_read",
		"SequenceId": 2,
		"TimeStamp": 1248377,
		"TrackingId": "55A6BCD4-0857-4A86-85FB-09A228B641B4",
		"access_token":"{{access_token}}"
	}
}'

	"data": {
		"master": "workshop_model",
        "filters": [
                {
		  "field": "brand_code",
		  "operation": "=",
		  "value": "TY"
		}
	},
	"header": {
		"FlowName": "masterdata_read",
		"SequenceId": 2,
		"TimeStamp": 1248377,
		"TrackingId": "55A6BCD4-0857-4A86-85FB-09A228B641B4",
		"access_token":"{{token}}"
        }
    }


#ejemplo
curl -s --location --request GET \
'https://api.pilotsolution.net/v1/masters/read.php' \
--header 'content-type: application/json' \
--data-raw "{
    \"data\": {
        \"master\": \"business_type\"
    },
    \"header\": {
        \"FlowName\": \"masterdata_read\",
        \"SequenceId\": 2,
        \"TimeStamp\": 1248377,
        \"TrackingId\": \"55A6BCD4-0857-4A86-85FB-09A228B641B4\",
        \"access_token\": \"$TOKEN\"
    }
}" | jq

#Resultado
  "ts": "1789147717",
  "_id": "474001577",
  "result": {
    "status": "success",
    "aditional_data": {
      "page": 1,
      "page_count": 1,
      "rows_count": 8,
      "rows_per_page": 25,
      "rows_in_page": 8,
      "rows_remaining": 0
    },
    "entitydata": [
      {
        "id": "1",
        "code": "GL",
        "name": "Gol Trend",
        "deleted": "1",
        "visible": "0",
        "visual_order": 1,
        "brand": {
          "code": "VW",
          "name": "Volkswaguen"
        },
        "audit_dt": "2019-03-15T20:20:14.400",
        "audit_user_id": "85955"
      },
      {
        "id": "2",
        "code": "FC",
        "name": "Focus",
        "deleted": "1",
        "visible": "0",
        "visual_order": 2,
        "brand": {
          "code": "FD",
          "name": "Ford"
        },
        "audit_dt": "2019-03-15T20:20:01.173",
        "audit_user_id": "85955"
      },
      {
        "id": "3",
        "code": "FI",
        "name": "Fiesta",
        "deleted": "1",
        "visible": "0",
        "visual_order": 3,
        "brand": {
          "code": "FD",
          "name": "Ford"
        },
        "audit_dt": "2019-03-15T20:19:58.523",
        "audit_user_id": "85955"
      },
      {
        "id": "4",
        "code": "SR",
        "name": "Suran",
        "deleted": "1",
        "visible": "0",
        "visual_order": 4,
        "brand": {
          "code": "VW",
          "name": "Volkswaguen"
        },
        "audit_dt": "2019-03-15T20:20:17.377",
        "audit_user_id": "85955"
      },
      {
        "id": "5",
        "code": "CR",
        "name": "Corsa",
        "deleted": "1",
        "visible": "0",
        "visual_order": 5,
        "brand": {
          "code": "CH",
          "name": "Chevrolet"
        },
        "audit_dt": "2019-03-15T20:19:50.357",
        "audit_user_id": "85955"
      },
      {
        "id": "6",
        "code": "AV",
        "name": "Aveo",
        "deleted": "1",
        "visible": "0",
        "visual_order": 6,
        "brand": {
          "code": "CH",
          "name": "Chevrolet"
        },
        "audit_dt": "2019-03-15T20:19:52.750",
        "audit_user_id": "85955"
      },
      {
        "id": "7",
        "code": "ET",
        "name": "Etios",
        "deleted": "1",
        "visible": "0",
        "visual_order": 7,
        "brand": {
          "code": "TY",
          "name": "Totyota"
        },
        "audit_dt": "2019-03-15T20:20:09.490",
        "audit_user_id": "85955"
      },
      {
        "id": "8",
        "code": "CL",
        "name": "Corolla",
        "deleted": "1",
        "visible": "0",
        "visual_order": 8,
        "brand": {
          "code": "TY",
          "name": "Totyota"
        },
        "audit_dt": "2019-03-15T20:20:06.153",
        "audit_user_id": "85955"
      }
    ]
  }
}