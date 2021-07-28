package com.reemii.bdmap;

/**
 * Author: yyg
 * Date: 2019-12-19 14:53
 * Description:
 */
public class RMLocation {
    public double lat;
    public double lng;
    public float direction;
    public float alt;
    public float speed;

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLng() {
        return lng;
    }

    public void setLng(double lng) {
        this.lng = lng;
    }

    public float getDirection() {
        return direction;
    }

    public void setDirection(float direction) {
        this.direction = direction;
    }

    @Override
    public String toString() {
        return "RMLocation{" +
                "lat=" + lat +
                ", lng=" + lng +
                ", direction=" + direction +
                ", alt=" + alt +
                ", speed=" + speed +
                '}';
    }
}
